# WordPress Docker Stack

My favourite Docker stack for WordPress.

## Setup steps

1. Copy example.env to .env and make your changes
1. Add your SSL certificate — I've included a certificate and key for the *.localdev domain, 
but you'll probably want to use your own:
    1. If you need to create your own wildcard certificate, you can use my script: [create-wildcard-certificate.sh](https://gist.github.com/jonpontet/83f361768f5809ad2b7ea82545ead767)
    1. Move your *.crt and *.key files to "./conf/apache/certificates/"
    1. Update "./conf/apache/000-default.conf" with the names of your *.crt and *.key files (line #60 and #61)
1. Build the Docker image: `docker build -t [image name]:latest .`
1. Add the name of this image to docker-compose.yml for the web container (line #31)
1. Add the local hostname to docker-compose.yml (line #37, #41)
1. Update the name, description and homepage in composer.json with your own
1. Start Docker: `make docker-up`
1. Install Composer dependencies (including WordPress Core): `make composer-i [local|prod]`
1. Initialise the environment: `make init [local|prod]`
1. Install WordPress (in the database) via the browser with the famous 5-minute install
1. Clean-up files, plugins & themes: `make clean-up [local|prod]`