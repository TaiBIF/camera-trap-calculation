import logging
from os.path import join

import pandas as pd
from flask import Flask, jsonify, request, url_for
from scripts.NOEveryThing.NOEveryThing import nopne

# Global 
file_dir = "/mnt/s3mountfile/data_for_calculation/"

app = Flask(__name__)

@app.route('/')
def root():
    pass

# basic-calculation 
@app.route('/basic-calculation', methods=['GET'])
def NOEveryThing():
    id = request.args.get("id", type=str, default=None)        # parameter
    
    # define logging format
    FORMAT = '%(asctime)s - %(levelname)s - %(filename)s - %(funcName)s - %(lineno)s - %(message)s' 
    handler = logging.FileHandler(file_dir + id + '/status.log', encoding='UTF-8')
    handler.setLevel(logging.DEBUG)
    logging_format = logging.Formatter(FORMAT)
    handler.setFormatter(logging_format)
    app.logger.addHandler(handler)

    try: 
        file_path = join(file_dir, id + "/dat.csv") 
        
        # Read and Calculate
        orig_dt = pd.read_csv(file_path) 
        output = orig_dt.groupby("cameraLocation").apply(nopne)
        output.to_csv(file_dir + id + "/results.csv", index=False)
        app.logger.info('Progress Success')                  # logging running message
        return "SUCCESS"

    except:
        app.logger.error("Progress Failed")                              # logging error message

def main():
    app.run(host="10.0.10.31", port=80, debug=True)

if __name__ == '__main__':
    main()
