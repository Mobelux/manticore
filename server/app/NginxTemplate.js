var config = require('../config.js');

module.exports = function () {
    return new NginxTemplate();
}

//function constructor for making nginx conf files
function NginxTemplate () {
    this.file = "";
}

NginxTemplate.prototype.get = function () {
    return this.file;
}

//make a new server block
NginxTemplate.prototype.server = function (port, isDefault, prefix, proxyAddr, isWebSocket) {
    var defaultString = "";
    if (isDefault) {
        defaultString = "default_server";
    }
    //if prefix exists, add a dot to the end of the string
    var prefixString = "";
    if (prefix) {
        prefixString = prefix + ".";
    }
    var serverString = `
server {
    listen ${port} ${defaultString};
    server_name ${prefixString}${config.domainName};
    location / {`;

    this.file += serverString;

    serverString = `
        proxy_pass http://${proxyAddr};
`;
    this.file += serverString;
    //add extra proxy settings if using a websocket connection
    if (isWebSocket) {
        serverString = `
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
`;

        this.file += serverString;
    }
    //end the location block and the server block
    this.file += `
    }
}
`;

    return this;
}