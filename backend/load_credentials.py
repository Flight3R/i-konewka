def get_plantid_api_key(file_path):
    """
    :raises FileNotFoundError
    """
    with open(file_path, 'r') as api_key_file:
        api_key = api_key_file.read().strip()
    return api_key


def get_openai_api_key(file_path):
    """
    :raises FileNotFoundError
    """
    with open(file_path, 'r') as api_key_file:
        api_key = api_key_file.read().strip()
    return api_key


def get_database_credentials(file_path):
    """
    :raises FileNotFoundError
    """
    with open(file_path, 'r') as database_details_file:
        database_config = {}
        for key, line in zip(['HOST', 'DATABASE', 'USER', 'PASSWORD'], database_details_file):
            database_config[key] = line.strip()
    return database_config
