import os
import base64
from logger import logger

def load_secret(secret_key):
    logger.info(f"Loading secret {secret_key=}")
    secret_value = os.environ.get(secret_key)
    if secret_value is None:
        logger.critical(f"Loading secret {secret_key=} failed!")
        raise ValueError
    logger.info(f"Secter loaded successbully: {secret_value=}")
    return secret_value
