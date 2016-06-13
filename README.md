# webpack-server.el
Mode for running the webpack-dev-server in emacs.

## Usage
<kbd>M-x</kbd> `webpack-server-run`
Starts the server in the *webpack-dev-server* comint buffer. If the server is running it will switch to the buffer. If run while buffer is active it will restart the server.

<kbd>M-x</kbd> `webpack-server-browse`  - Open a tab at the development server

To manually start, stop or restart use:
<kbd>M-x</kbd> `webpack-server-start` 
<kbd>M-x</kbd> `webpack-server-stop`
<kbd>M-x</kbd> `webpack-server-restart`
