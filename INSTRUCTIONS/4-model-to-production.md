# Model to production

## Model training

   ```bash
   jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser
   ```
And connect to in in your browswer.

Upload the [labeled-dataset](/AWS/EC2/NLP-model/training/labeled-training-dataset.csv) and the [notebook](/AWS/EC2/NLP-model/training/model-trained-EC2.ipynb) --> to the same directory

The script will store the model in the EC2 as "trained-model"

## Production Model
Once the model is stored in the EC2 memory, we just need to call it with production data that is what the [python script](/AWS/EC2/production-pipeline.py) does. 

## Automate the process
In order to process incoming data, the EC2 will run automatically the above script thanks to the [user data script](/AWS/EC2/production/user-data.sh) which are commands that are executed everytime the instance is launched. Besides, this will stop the instance when done, saving a lot of costs.