import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('storage/ikonewka_backend.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def log(logger_func, message, *args, **kwargs):
    log_message = message
    if args or kwargs:
        log_message = f'{message}:'
        if args:
            log_message = f"{log_message} {' '.join(args)}"
        if kwargs:
            kwargs_message = ' '.join([f'{key}={value}' for key, value in kwargs.items()])
            log_message = f'{log_message} {kwargs_message}'

    logger_func(log_message)