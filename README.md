# dwac (Dark Wing Acceses Control)
## Introduce
  Dwac is a simple solution for multi-program access control on Linux. It helps you prevent the access to specific sites you define. By using a general filter standing at the DNS lookup process, the program can block request from any browser or any program using normal HTTP request. Hopefully, this is safe enough for normal users :)
  
## Install
  First, clone this project source into a safe place (make sure that you don't remove this folder). Then set executable permission to .sh files in the folder and run install.
  ```
  git clone git@github.com:nguyenquangminh0711/dwac.git && cd dwac
  chmod +x+r ./*.sh
  sudo ./install.sh
  ```
  And done :). You can check again by running 
  ```
  dwac help
  ```
  
## Uninstall
  Go to program source folder and run:
  ```
  sudo ./uninstall.sh
  ```
  
### Usage
  First, add a site to block list
  ```
  dwac add facebook.com
  ```
  Then start program and enjoy :)
  ```
  dwac start
  ```
  
  To remove a site from block list, run:
  ```
  dwac remove facebook.com
  ```
  
  Then restart program to update by running
  ```
  dwac restart
  ```
  
  List of all commands are available at
  ```
  dwac help
  ```
### Credit
  - **Author**: Minh Nguyen (nguyenquangminh0711@gmail.com)
  - **License**: MIT
