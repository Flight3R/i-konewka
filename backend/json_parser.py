from exception import JsonReadException


def get_is_plant_from_json(json_data: str) -> bool:
    """
    Reads from JSON plant probability.

    :raises JsonReadException
    """
    try:
        is_plant_prob = json_data['result']['is_plant']['probability']
        return True if is_plant_prob > 0.95 else False
    except KeyError as e:
        raise JsonReadException(f'Could not read fields from JSON: {e}')


def get_flower_name_from_json(json_data: str) -> str:
    """
    Reads from JSON plant's name.

    :raises JsonReadException
    """
    try:
        plant_name = json_data['result']['classification']['suggestions'][0]['name']
        return plant_name
    except KeyError as e:
        raise JsonReadException(f'Could not read fields from JSON: {e}')


def get_is_flower_healthy_from_json(json_data: str) -> str:
    """
    Reads from JSON if plant is heatlhy.

    :raises JsonReadException
    """
    try:
        plant_is_healthy_prob = json_data['result']['is_healthy']['probability']
        return True if plant_is_healthy_prob > 0.5 else False
    except KeyError as e:
        raise JsonReadException(f'Could not read fields from JSON: {e}')


def get_flower_disease_from_json(json_data: str) -> str:
    """
    Reads from JSON plant's disease.

    :raises JsonReadException
    """
    try:
        plant_disease = json_data['result']['disease']['suggestions'][0]['name']
        return plant_disease
    except KeyError as e:
        raise JsonReadException(f'Could not read fields from JSON: {e}')
