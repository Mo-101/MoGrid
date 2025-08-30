import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def dispatch_events():
    logger.info('Checking for undispatched events...')

if __name__ == '__main__':
    while True:
        dispatch_events()
        time.sleep(10)
