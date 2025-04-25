# Machine learning classification software for detecting guitar chords in real-time
This program is meant to assist novice guitar players in correctly identifying guitar chords, while playing and learning guitar.

Before running the program, MATLAB needs to be installed on your computer.

Hardware-wise, you need to connect an NVIDIA Jetson with an external USB-camera to your PC.

# NVIDIA Jetson
## Set up the project on Jetson 
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

## How to run inference on Jetson
1. Enter the repository and run docker-compose  
```
cd SMC7-Semester-Project  
sudo docker-compose up -d
```
> The first start-up will take longer since docker has to pull the container image from Nvidia’s repository

2. After you see a message that the container is running, you can access Jupyter through `http://192.168.55.1:8888/` on the host computer   
3. To acces the JupyterLab type in the password: `Password: nvidia`  
4. Open the `Camera Input to Model.ipynb` notebook and run it
   * To make sure your Jetson will correcly send UDP packets to your MATLAB Plugin, you need to modify `UDP_IP` variable inside the notebook (`How to send UDP from python` cell). You can find your PC's IP by opening a Windows command line and running the `ipconfig` command.
6. After finishing work with notebooks you can stop docker with a docker compose down comand:
 ```
 sudo docker-compose down
 ```

---
# MATLAB
## Generate MATLAB Audio Plugin
1. Open MATLAB and go to this project location on your device
2. In MATLAB's command line run
```
generateAudioPlugin -exe PlayChord
```

## How to run MatLab Generated Plugin
1. Open Windows command line or Windows Powershell
2. Go to this project location
```
cd <path_to_project>
```
3. Set required PATH variables. In case you have a different version of MATLAB installed correct the path in the command.
```
set PATH='<path_to_matlab>\bin\win64'%PATH%;
```
Ex. `set PATH='C:\Program Files\MATLAB\R2023a\bin\win64'%PATH%;`  

4. Run the .exe file 
```
./PlayChord.exe
```

