FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

# প্রয়োজনীয় টুলস এবং প্যাকেজ ইনস্টল করা (Firefox বাদ দেওয়া হয়েছে)
RUN apt update && apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32 \
    vlc \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Google Chrome ইনস্টল করা
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt update && apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# নতুন ইউজার 'user' এবং ৪ সংখ্যার পাসওয়ার্ড '1234' সেট করা
RUN useradd -m -s /bin/bash user && \
    echo "user:1234" | chpasswd && \
    usermod -aG sudo,audio,video user

# X11 কনফিগারেশন
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# নতুন ইউজারের জন্য XFCE4 সেশন সেটআপ
RUN echo "startxfce4" > /home/user/.xsession && \
    chown user:user /home/user/.xsession

# dbus এর জন্য machine-id তৈরি
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# XRDP কনফিগারেশন
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
