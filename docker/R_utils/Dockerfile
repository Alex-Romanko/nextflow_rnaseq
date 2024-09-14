FROM r-base

MAINTAINER romanko.aleksandr.a@gmail.com
ENTRYPOINT ["/bin/bash"]

RUN apt-get update && DEBIAN_FRONTEND=noninteractive
# Set timezone:
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN R -e "install.packages('tidyverse',dependencies=TRUE, repos='https://cloud.r-project.org/')"

COPY ./merge_star_tsv.R /usr/local/bin/
RUN chmod +x /usr/local/bin/merge_star_tsv.R

ENV PATH /usr/local/bin:$PATH
