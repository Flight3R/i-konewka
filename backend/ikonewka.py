from flask import Flask, jsonify, request
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, verify_jwt_in_request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone, timedelta
import enum
from load_credentials import get_database_credentials
from plantid import identify_flower
from exception import JsonReadException, IsNotPlantException, PlainIdResponseException
from chatgpt import get_flower_type_watering_details_from_openai

app = Flask(__name__)
CORS(app)

database_data = get_database_credentials("database_credentials")

HOST=database_data['HOST']
DATABASE=database_data['DATABASE']
USER=database_data['USER']
PASSWORD=database_data['PASSWORD']

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{USER}:{PASSWORD}@{HOST}:3306/{DATABASE}'
db = SQLAlchemy(app)

app.config['JWT_SECRET_KEY'] = 'your_jwt_secret_key'  # Change this to a random and secure key in production
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(minutes=15)
jwt = JWTManager(app)


class WeekdayActivation(enum.Enum):
    TRUE=1
    FALSE=0


class Users(db.Model):
    __tablename__ = 'USERS'
    uid = db.Column(db.Integer, primary_key=True)
    nick = db.Column(db.String, nullable=False)
    nof_flowers = db.Column(db.Integer, default=0)
    email = db.Column(db.String, nullable=False)
    password = db.Column(db.String, nullable=False)
    watering_hour = db.Column(db.Integer, nullable=False)
    start = db.Column(db.DateTime, default=datetime.now(timezone.utc))


class Flowers_type(db.Model):
    __tablename__ = 'FLOWERS_TYPE'
    ftid = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, nullable=False)
    note = db.Column(db.String)
    nof_watering_days = db.Column(db.Integer, nullable=False)
    ml_per_watering = db.Column(db.Integer, nullable=False)


class Flowers(db.Model):
    __tablename__ = 'FLOWERS'
    fid = db.Column(db.Integer, primary_key=True)
    uid = db.Column(db.Integer, db.ForeignKey('USERS.uid'), nullable=False)
    ftid = db.Column(db.Integer, db.ForeignKey('FLOWERS_TYPE.ftid'), nullable=False)
    name = db.Column(db.String, nullable=False)
    health = db.Column(db.String, nullable=False)
    start = db.Column(db.DateTime, default=datetime.now(timezone.utc))
    monday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    tuesday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    wednesday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    thursday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    friday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    saturday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)
    sunday = db.Column(db.Enum(WeekdayActivation), default=WeekdayActivation.FALSE)


class History(db.Model):
    __tablename__ = 'HISTORY'
    hid = db.Column(db.Integer, primary_key=True)
    fid = db.Column(db.Integer, db.ForeignKey('FLOWERS.fid'), nullable=False)
    uid = db.Column(db.Integer, db.ForeignKey('USERS.uid'), nullable=False)
    watering = db.Column(db.DateTime, default=datetime.now(timezone.utc))


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


        new_user = Users(nick = data['nick'],
                         email = data['email'],
                         password = data['password'],
                         watering_hour = data['watering_hour'])

        db.session.add(new_user)
        db.session.commit()

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
        print(user)
        if user:
            access_token = create_access_token(identity=user.uid)
            return jsonify(access_token), 200
        else:
            return jsonify({'error': 'Invalid email or password'}), 401
    except Exception as e:
        print(e)
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


@app.route('/auth/validate', methods=['GET'])
@jwt_required()
def validate_token():
    current_user = get_jwt_identity()
    return jsonify(message=f'Token is valid for user {current_user}'), 200


@app.route('/api/user_information', methods=['GET'])
@jwt_required()
def get_user_information():
    current_user_id = get_jwt_identity()
    user_data = Users.query.filter_by(uid=current_user_id).first()

    if user_data:
        user_information = {'flowers_count': user_data.nof_flowers,
                            'watering_hour': user_data.watering_hour}
        return jsonify({'user_information': user_information})
    else:
        return jsonify({'error': f'User with ID {current_user_id} not found'}), 404


@app.route('/api/flower/', methods=['PUT'])
@jwt_required()
def add_flower():
    """
    :catches JsonReadException, PlainIdResponseException, IsNotPlantException
    """
    try:
        data = request.get_json()
        current_user_id = get_jwt_identity()

        if any([param not in data for param in ['flower_name', 'flower_image']]):
            return jsonify({'error': 'Missing required fields (flower_name, flower_image)'}), 400

        try:
            found_flower_name = identify_flower(data['flower_image'])

        except JsonReadException as e:
            return jsonify({'error': 'Could not retrieve information from PlantId response'}), 504

        except PlainIdResponseException as e:
            return jsonify({'error': e}), 504

        except IsNotPlantException as e:
            return jsonify({'error': e}), 418

        found_flower_type =  Flowers_type.query.filter_by(name=found_flower_name).first()

        if not found_flower_type:
            flower_type_details = get_flower_type_watering_details_from_openai(found_flower_name)
            new_flower_type = Flowers_type(name = found_flower_name,
                                nof_watering_days = flower_type_details['nof_watering_days'],
                                ml_per_watering = flower_type_details['ml_per_watering'])

            db.session.add(new_flower_type)
            db.session.commit()
            new_flower_type_id = new_flower_type.ftid
        else:
            new_flower_type_id = found_flower_type.ftid

        new_flower = Flowers(uid = current_user_id,
                                ftid = new_flower_type_id,
                                name=data['flower_name'],
                                health = None, # TODO add automatic health assessment
                                )
        db.session.add(new_flower)
        db.session.commit()

        return jsonify({'message': 'Flower added successfully'})
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


if __name__ == '__main__':
    app.run(host='192.168.0.2', port=5000, debug=True)

