import requests
import json
from load_credentials import get_plantid_api_key
from json_parser import get_is_plant_from_json, get_flower_name_from_json
from logger import logger
from exception import PlainIdResponseException, IsNotPlantException

API_KEY = get_plantid_api_key('plantid_api_key')
IDENTIFICATION_URL = 'https://plant.id/api/v3/identification'
HEALTH_ASSESSMENT_URL = 'https://plant.id/api/v3/health_assessment'
HEADERS = {
    'Api-Key': API_KEY,
    'Content-Type': 'application/json',
}


def identify_flower(flower_image_base64) -> str:
    """
    Performs flower identification using PlantId API

    :raises PlainIdResponseException
    :forwards JsonReadException
    """
    data = {
        'images': ['data:image/jpg;base64,' + flower_image_base64]
    }

    json_data = json.dumps(data)

    response = requests.post(IDENTIFICATION_URL, headers=HEADERS, data=json_data)

    if response.status_code != 200:
        raise PlainIdResponseException(f"PlantId responded with code {response.status_code}: {response}")

    # :raises JsonReadException
    is_plant = get_is_plant_from_json(response.json())

    if not is_plant:
        raise IsNotPlantException()

    # :raises JsonReadException
    flower_name = get_flower_name_from_json(response.json())

    return flower_name


def health_assessment(flower_image_base64) -> str:
    """
    Performs flower health assessment using PlantId API
    """
    data = {
        'images': ['data:image/jpg;base64,' + flower_image_base64]
    }

    json_data = json.dumps(data)

    response = requests.post(HEALTH_ASSESSMENT_URL, headers=HEADERS, data=json_data)

    if response.status_code != 200:
        raise PlainIdResponseException(f"PlantId responded with code {response.status_code}: {response}")

    # :raises
    # is_plant = get_is_plant_from_json(response.json())

    # if not is_plant:
    #     raise IsNotPlantException()

    # # :raises JsonReadException
    # flower_name = get_flower_name_from_json(response.json())

    # return flower_name

