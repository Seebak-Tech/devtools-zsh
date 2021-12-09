FROM ubuntu

ARG VERSION=0.0.0
ARG GIT_VERSION=v2.30.2

LABEL "Version" = $VERSION
LABEL "Name" = "devtools-zsh"

ENV TZ=America/Mexico_City

# Requirements for Time Zone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone 

# Installation Packages
RUN apt-get update \
    && apt-get install -y -q --allow-unauthenticated \
    build-essential \
    cmake \
    curl \
    fonts-powerline \
    gettext \
    iputils-ping \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    libssl-dev \
    locales \
    make \
    net-tools \
    sudo \
    tree \
    tzdata \
    vim  \
    wget \ 
    x11-apps \
    zlib1g-dev \
    zsh \
    zsh-syntax-highlighting \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    && wget -c https://github.com/git/git/archive/$GIT_VERSION.tar.gz -O - | sudo tar -xz -C /usr/src \
    && cd /usr/src/git-* \
    && make prefix=/usr/local all \
    && make prefix=/usr/local install \
    && cd /usr/src \
    && rm -rf git-*
  
# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen 

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 

# Add user admin
RUN useradd -m -s /bin/bash admin && \
    usermod -aG sudo admin && \
    passwd -d admin 

USER admin

WORKDIR /home/admin

# Switching from user's bash to zsh 
RUN sudo usermod -s /usr/bin/zsh $(whoami)

# Installing Oh-my-zsh and pluggins
RUN sh -c "$(wget -O- https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

COPY --chown=admin zshrc ./.zshrc

COPY --chown=admin p10k.zsh ./.p10k.zsh 

COPY --chown=admin gitstatusd-linux-x86_64 /home/admin/.cache/gitstatus/gitstatusd-linux-x86_64
