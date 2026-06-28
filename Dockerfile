FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

# প্রয়োজনীয় প্যাকেজসমূহ ইনস্টল করা
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
    firefox-esr \
    htop \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Google Chrome ইনস্টল করা
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt update && apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

# ক্রোমের স্যান্ডবক্স নিষ্ক্রিয় করা
RUN sed -i 's|/usr/bin/google-chrome-stable|/usr/bin/google-chrome-stable --no-sandbox|g' /usr/share/applications/google-chrome.desktop

# গুগল ক্রোমকে সিস্টেমের ডিফল্ট ব্রাউজার হিসেবে সেট করা
RUN update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome-stable 200 && \
    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable

# নেটওয়ার্ক বাফার অপ্টিমাইজেশন (ল্যাগ কমানোর জন্য)
RUN sed -i 's/#tcp_send_buffer_size=32768/tcp_send_buffer_size=1048576/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/#tcp_recv_buffer_size=32768/tcp_recv_buffer_size=1048576/g' /etc/xrdp/xrdp.ini

# নতুন ইউজার 'user' এবং পাসওয়ার্ড '1234' সেট করা
RUN useradd -m -s /bin/bash user && \
    echo "user:1234" | chpasswd && \
    usermod -aG sudo,audio,video user

# X11 কনফিগারেশন
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# ইউজারের জন্য স্টার্টআপ স্ক্রিপ্ট (কম্পোজিটিং বন্ধ রাখা হলো)
RUN echo "xfconf-query -c xfwm4 -p /general/use_compositing -s false" > /home/user/.xsession && \
    echo "exec startxfce4" >> /home/user/.xsession && \
    chmod +x /home/user/.xsession && \
    chown user:user /home/user/.xsession

# dbus এর জন্য machine-id তৈরি
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# XRDP সেটিংস রিসেট ও টিউনিং
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
