from flask import Flask, jsonify, request
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, verify_jwt_in_request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone, timedelta
from load_credentials import get_database_credentials, get_key
from plantid import identify_flower, health_assessment
from exception import JsonReadException, IsNotPlantException, PlainIdResponseException
from chatgpt import get_flower_type_watering_details_from_openai
from logger import logger
from helpers import is_weekday_active
from sqlalchemy import desc

app = Flask(__name__)
CORS(app)

database_data = get_database_credentials("database_credentials")

HOST = database_data['HOST']
DATABASE = database_data['DATABASE']
USER = database_data['USER']
PASSWORD = database_data['PASSWORD']

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:3306/{DATABASE}'
db = SQLAlchemy(app)

app.config['JWT_SECRET_KEY'] = get_key('jwt_key')  # Change this to a random and secure key in production
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(minutes=15)
jwt = JWTManager(app)


class Users(db.Model):
    __tablename__ = 'USERS'
    uid = db.Column(db.Integer, primary_key=True)
    start = db.Column(db.DateTime, default=datetime.now(timezone.utc))

    nick = db.Column(db.String, nullable=False)
    nof_flowers = db.Column(db.Integer, default=0)
    email = db.Column(db.String, nullable=False)
    password = db.Column(db.String, nullable=False)
    watering_hour = db.Column(db.Integer, nullable=False)


class Flower_types(db.Model):
    __tablename__ = 'FLOWER_TYPES'
    ftid = db.Column(db.Integer, primary_key=True)

    name = db.Column(db.String, nullable=False)
    note = db.Column(db.String)
    nof_watering_days = db.Column(db.Integer, nullable=False)
    ml_per_watering = db.Column(db.Integer, nullable=False)


class Flowers(db.Model):
    __tablename__ = 'FLOWERS'
    fid = db.Column(db.Integer, primary_key=True)
    start = db.Column(db.DateTime, default=datetime.now(timezone.utc))

    uid = db.Column(db.Integer, db.ForeignKey('USERS.uid'), nullable=False)
    ftid = db.Column(db.Integer, db.ForeignKey('FLOWER_TYPES.ftid'), nullable=False)
    name = db.Column(db.String, nullable=False)
    health = db.Column(db.String, nullable=False)
    ml_per_watering = db.Column(db.Integer, nullable=False)
    monday = db.Column(db.Integer, default=0)
    tuesday = db.Column(db.Integer, default=0)
    wednesday = db.Column(db.Integer, default=0)
    thursday = db.Column(db.Integer, default=0)
    friday = db.Column(db.Integer, default=0)
    saturday = db.Column(db.Integer, default=0)
    sunday = db.Column(db.Integer, default=0)


class History(db.Model):
    __tablename__ = 'HISTORY'
    hid = db.Column(db.Integer, primary_key=True)
    watering = db.Column(db.DateTime, default=datetime.now(timezone.utc))

    fid = db.Column(db.Integer, db.ForeignKey('FLOWERS.fid'), nullable=False)
    uid = db.Column(db.Integer, db.ForeignKey('USERS.uid'), nullable=False)


class Images(db.Model):
    __tablename__ = 'IMAGES'
    iid = db.Column(db.Integer, primary_key=True)
    fid = db.Column(db.Integer, db.ForeignKey('FLOWERS.fid'))
    image = db.Column(db.String, nullable=False)
    image_timestamp = db.Column(db.DateTime, default=datetime.now(timezone.utc))


@app.route('/auth/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        if any([param not in data for param in ['nick', 'email', 'password', 'watering_hour']]):
            return jsonify({'error': 'Missing required fields (nick, email, password, watering_hour)'}), 400


        new_user = Users(nick=data['nick'],
                         email=data['email'],
                         password=data['password'],
                         watering_hour=data['watering_hour'])

        db.session.add(new_user)
        db.session.commit()
        logger.info(f'User {new_user.uid} added.')
        return jsonify({'message': 'User added successfully'})
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        if any([param not in data for param in ['email', 'password']]):
            return jsonify({'error': 'Username and password are required'}), 400

        user = Users.query.filter_by(email=data['email'],
                                     password=data['password']).first()
        if user:
            access_token = create_access_token(identity=user.uid)
            return jsonify(access_token), 200
        else:
            return jsonify({'error': 'Invalid email or password'}), 401
    except Exception as e:
        logger.error(f'{request.get_data()=}')
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/user_information', methods=['GET'])
@jwt_required()
def get_user_information():
    try:
        current_user_id = get_jwt_identity()
        user_data = Users.query.filter_by(uid=current_user_id).first()

        if user_data:
            user_information = {'flowers_count': user_data.nof_flowers,
                                'watering_hour': user_data.watering_hour}
            return jsonify({'user_information': user_information})
        else:
            return jsonify({'error': f'User with ID {current_user_id} not found'}), 404
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/flower', methods=['POST'])
@jwt_required()
def add_flower():
    """
    :catches JsonReadException, PlainIdResponseException, IsNotPlantException
    """
    logger.debug('Flower addition request recieved.')
    try:
        data = request.get_json()
        current_user_id = get_jwt_identity()

        if any([param not in data for param in ['flower_name', 'flower_image']]):
            message = 'Missing required fields (flower_name, flower_image)'
            logger.error(message)
            return jsonify({'error': message}), 400

        try:
            logger.debug('Identifying flower by image.')
            found_flower_name = identify_flower(data['flower_image'])

        except JsonReadException as e:
            message = 'Could not retrieve information from PlantId response'
            logger.error(message)
            return jsonify({'error': message}), 504

        except PlainIdResponseException as e:
            logger.error(e)
            return jsonify({'error': e}), 504

        except IsNotPlantException as e:
            logger.error(e)
            return jsonify({'error': e}), 418

        logger.debug('Searching for flower type in database.')

        found_flower_type =  Flower_types.query.filter_by(name=found_flower_name).first()
        if found_flower_type:
            logger.debug(f'Found flower type in database: {found_flower_name}.')
            nof_watering_days = found_flower_type.nof_watering_days
            ml_per_watering = found_flower_type.ml_per_watering
            new_flower_type_id = found_flower_type.ftid
        else:
            logger.info(f'Adding new flower type: {found_flower_name}.')
            flower_type_details = get_flower_type_watering_details_from_openai(found_flower_name)
            new_flower_type = Flower_types(name=found_flower_name,
                                           nof_watering_days=flower_type_details['nof_watering_days'],
                                           ml_per_watering=flower_type_details['ml_per_watering'])
            db.session.add(new_flower_type)
            db.session.commit()
            nof_watering_days = flower_type_details['nof_watering_days']
            ml_per_watering = flower_type_details['ml_per_watering']
            new_flower_type_id = new_flower_type.ftid

        logger.debug('Flower health assessment by image.')
        new_flower_health = health_assessment(data['flower_image'])

        watering_schedule = is_weekday_active(nof_watering_days)
        new_flower = Flowers(uid=current_user_id,
                             ftid=new_flower_type_id,
                             name=data['flower_name'],
                             health=new_flower_health,
                             ml_per_watering = ml_per_watering,
                             monday=watering_schedule['monday'],
                             tuesday=watering_schedule['tuesday'],
                             wednesday=watering_schedule['wednesday'],
                             thursday=watering_schedule['thursday'],
                             friday=watering_schedule['friday'],
                             saturday=watering_schedule['saturday'],
                             sunday=watering_schedule['sunday'])

        db.session.add(new_flower)
        db.session.commit()

        new_image = Images(fid=new_flower.fid,
                           image=data['flower_image'])
        db.session.add(new_image)
        db.session.commit()

        user = Users.query.filter_by(uid=current_user_id).first()
        user.nof_flowers = user.nof_flowers + 1
        db.session.commit()

        return jsonify({'message': 'Flower added successfully'})
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/flower/<fid>', methods=['PUT'])
@jwt_required()
def update_flower(fid):
    try:
        data = request.get_json()
        current_user_id = get_jwt_identity()

        flower_to_update = Flowers.query.filter_by(fid=fid, uid=current_user_id).first()

        if flower_to_update:
            data = request.get_json()

            if 'name' in data:
                flower_to_update.name = data['name']

            if 'ml_per_watering' in data:
                flower_to_update.ml_per_watering = data['ml_per_watering']

            for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']:
                if day in data:
                    setattr(flower_to_update, day, data[day])

            db.session.commit()

            return jsonify({'message': f'Flower with ID {fid} updated successfully'})
        else:
            return jsonify({'error': f'Flower with ID {fid} not found or does not belong to the user'}), 404

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/flower/<fid>', methods=['GET'])
@jwt_required()
def get_flower_details(fid):
    try:
        flower_id = fid
        current_user_id = get_jwt_identity()

        flower_detail = Flowers.query.filter_by(fid=flower_id, uid=current_user_id).first()

        if flower_detail:
            flower_info = {
                'fid': flower_detail.fid,
                'name': flower_detail.name,
                'health': flower_detail.health,
                'monday': flower_detail.monday,
                'tuesday': flower_detail.tuesday,
                'ml_per_watering': flower_detail.ml_per_watering,
                'wednesday': flower_detail.wednesday,
                'thursday': flower_detail.thursday,
                'friday': flower_detail.friday,
                'saturday': flower_detail.saturday,
                'sunday': flower_detail.sunday
            }

            latest_image = Images.query.filter_by(fid=flower_id).order_by(desc(Images.image_timestamp)).first()

            if latest_image:
                flower_info['image'] = latest_image.image
            else:
                flower_info['image'] = None

            return jsonify({'flower_detail': flower_info})
        else:
            return jsonify({'error': f'Flower with ID {flower_id} not found or does not belong to the user'}), 404

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/flower/<fid>', methods=['DELETE'])
@jwt_required()
def delete_flower(fid):
    try:
        current_user_id = get_jwt_identity()

        flower_to_delete = Flowers.query.filter_by(fid=fid, uid=current_user_id).first()

        if flower_to_delete:
            History.query.filter_by(fid=fid).delete()
            Images.query.filter_by(fid=fid).delete()

            db.session.delete(flower_to_delete)

            user = Users.query.filter_by(uid=current_user_id).first()
            user.nof_flowers = user.nof_flowers - 1
            db.session.commit()

            return jsonify({'message': f'Flower with ID {fid} deleted successfully'})
        else:
            return jsonify({'error': f'Flower with ID {fid} not found or does not belong to the user'}), 404

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/flower_photo', methods=['POST'])
@jwt_required()
def add_flower_photo():
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        if any([param not in data for param in ['fid', 'image']]):
            return jsonify({'error': 'Missing required fields (fid, image)'}), 400
        fid = data['fid']
        image = data['image']

        flower = Flowers.query.filter_by(fid=fid, uid=current_user_id).first()

        if flower:
            flower_health = health_assessment(image)

            new_image = Images(fid=fid, image=image)
            db.session.add(new_image)
            setattr(flower, 'health', flower_health)
            db.session.commit()

            return jsonify({'message': f'Image {new_image.iid} of flower {fid} added successfully'})
        else:
            return jsonify({'error': f'Flower with ID {fid} not found or does not belong to the user'}), 404

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/user_flowers', methods=['GET'])
@jwt_required()
def get_user_flowers():
    try:
        current_user_id = get_jwt_identity()
        user_flowers = Flowers.query.filter_by(uid=current_user_id).all()

        flowers_list = []

        for flower in user_flowers:
            flower_info = {
                'fid': flower.fid,
                'name': flower.name,
                'health': flower.health,
                'ml_per_watering': flower.ml_per_watering,
                'monday': flower.monday,
                'tuesday': flower.tuesday,
                'wednesday': flower.wednesday,
                'thursday': flower.thursday,
                'friday': flower.friday,
                'saturday': flower.saturday,
                'sunday': flower.sunday
            }

            latest_image = Images.query.filter_by(fid=flower.fid).order_by(desc(Images.image_timestamp)).first()

            if latest_image:
                flower_info['image'] = latest_image.image
            else:
                flower_info['image'] = None

            flowers_list.append(flower_info)

        return jsonify({'user_flowers': flowers_list})

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/watering', methods=['POST'])
@jwt_required()
def add_watering():
    try:
        data = request.get_json()
        current_user_id = get_jwt_identity()

        if 'fid' not in data :
            message = 'Missing required fields (fid)'
            logger.error(message)
            return jsonify({'error': message}), 400

        new_watering = History(uid=current_user_id,
                               fid=data['fid'])

        db.session.add(new_watering)
        db.session.commit()
        logger.info(f'New watering {new_watering.hid} added.')
        return jsonify({'message': 'Watering added successfully'})
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/api/watering/<fid>/<nof_waterings>', methods=['GET'])
@jwt_required()
def get_last_watering(fid, nof_waterings):
    try:
        current_user_id = get_jwt_identity()

        flower = Flowers.query.filter_by(fid=fid, uid=current_user_id).first()

        if not flower:
            return jsonify({'error': f'Flower with ID {fid} was not water or does not belong to the user'}), 404

        last_waterings = History.query.filter_by(fid=fid, uid=current_user_id).order_by(desc(History.watering)).limit(nof_waterings).all()

        waterings_list = [
            {
                'watering_timestamp': watering.watering.isoformat(),
            }
            for watering in last_waterings
        ]

        return jsonify({'last_waterings': waterings_list})

    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


if __name__ == '__main__':
    app.run(host='192.168.0.2', port=60001, debug=True)
