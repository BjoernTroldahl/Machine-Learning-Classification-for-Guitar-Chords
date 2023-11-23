# SMC7-Semester-Project
Version control for the SMC7 project
GitHub


### How to run inference on Jetson
1. Install Docker Compose
```
curl -SL https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-aarch64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
2. Clone the repository to Jetson  
```
git clone https://github.com/BjoernTroldahl/SMC7-Semester-Project.git
```
3. Enter the repository and run docker-compose  
```
cd SMC7-Semester-Project  
sudo docker-compose up -d
```
> The first start-up will take longer since docker has to pull the container image from Nvidia’s repository

4. After you see a message that the container is running, you can access Jupyter through `http://192.168.55.1:8888/` on the host computer   
5. To acces the JupyterLab type in the password: `Password: nvidia`  
6. Open the `Camera Input to Model.ipynb` notebook and run it