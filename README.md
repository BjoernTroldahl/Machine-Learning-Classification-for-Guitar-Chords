# SMC7-Semester-Project
Version control for the SMC7 project
GitHub


### How to run inference on Jetson
1. Install Docker Compose
```
sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.1/docker-compose-linux-aarch64 -o /usr/local/bin/docker-compose
```
```
sudo chmod +x /usr/local/bin/docker-compose
```
2. Clone the repository to Jetson  
```
git clone https://github.com/BjoernTroldahl/SMC7-Semester-Project.git
```

You will be asked for your github credentials during the clone process. Instead of your GitHub password use a personal access token which you can generate in the following way: 
> Create Personal Access Token on GitHub  
> From your GitHub account, go to Settings → Developer Settings → Personal Access Token → Generate New Token → Fillup the form → click Generate token → Copy the generated Token, it will be something
> like `ghp_sFhFsSHhTzMDreGRLjmks4Tzuzgthdvfsrta`

3. Enter the repository and run docker-compose  
```
cd SMC7-Semester-Project  
sudo docker-compose up -d
```
> The first start-up will take longer since docker has to pull the container image from Nvidia’s repository

4. After you see a message that the container is running, you can access Jupyter through `http://192.168.55.1:8888/` on the host computer   
5. To acces the JupyterLab type in the password: `Password: nvidia`  
6. Open the `Camera Input to Model.ipynb` notebook and run it
7. After finishing work with notebooks you can stop docker with a comand:
 ```
 sudo docker-compose down
 ```
