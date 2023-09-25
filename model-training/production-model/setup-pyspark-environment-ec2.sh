sudo apt-get update
sudo apt install python3-pip
pip install jupyter
sudo apt install jupyter-notebook
sudo apt-get install default.jre
sudo apt-get install scala
pip3 install py4j
wget https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
sudo tar -zxvf spark-3.5.0-bin-hadoop3.tgz
pip install findspark
sudo apt install python3-venv
python3 -m venv spark_env # name as you prefer in my case I chose --> spark_env
pip install pyspark
jupyter notebook --generate-config
mkdir certs
cd certs/
sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem
cd ~
jupyter notebook

# Followin this steps a jupyter notebook will be created in the EC2 instance
# In my case, I'll be using it from my local machine, using public IP DNS of the EC2 instance, that will give access to the UI Jupyter