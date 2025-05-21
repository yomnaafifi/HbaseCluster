FROM ubuntu:22.04 AS hadoop 

RUN apt update -y && apt upgrade -y && \
    apt install -y openjdk-8-jdk ssh sudo nano

RUN mv  /usr/lib/jvm/java-8-openjdk-amd64/ /usr/lib/jvm/java

# Set JAVA_HOME and update PATH in bashrc
ENV JAVA_HOME=/usr/lib/jvm/java
ENV PATH=$PATH:$JAVA_HOME/bin


RUN groupadd hadoop && \
    adduser --disabled-password --ingroup hadoop hduser && \
    echo "hduser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


ADD https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz /usr/local
RUN tar -xzf /usr/local/hadoop-3.3.6.tar.gz -C /usr/local && \
    mv /usr/local/hadoop-3.3.6 /usr/local/hadoop && \
    chown -R hduser:hadoop /usr/local/hadoop && \
    chmod -R 755 /usr/local/hadoop

#create the files for hdfs (tmp,hdfs,namenode, datanode)
RUN mkdir -p /usr/local/hadoop/hdfs/namenode && \
    mkdir -p /usr/local/hadoop/hdfs/datanode && \
    mkdir -p /usr/local/hadoop/hdfs/journals && \
    mkdir -p /usr/local/hadoop/tmp && \
    chown -R hduser:hadoop /usr/local/hadoop/hdfs/namenode && \
    chown -R hduser:hadoop /usr/local/hadoop/hdfs/datanode && \
    chown -R hduser:hadoop /usr/local/hadoop/hdfs/journals && \
    chown -R hduser:hadoop /usr/local/hadoop/tmp

ADD https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz /usr/local
RUN tar -xzf /usr/local/apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local && \
    mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper && \
    chown -R hduser:hadoop /usr/local/zookeeper && \
    chmod -R 755 /usr/local/zookeeper && \
    mkdir -p /usr/local/zookeeper/data && \
    chown -R hduser:hadoop /usr/local/zookeeper/data && \
    chmod -R 777 /usr/local/zookeeper/data && \
    touch /usr/local/zookeeper/data/myid && \
    chmod -R 777 /usr/local/zookeeper/data/myid

RUN mkdir -p /usr/local/shared_data
RUN chown -R hduser:hadoop /usr/local/shared_data
RUN chmod -R 777 /usr/local/shared_data

ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin
ENV PATH=$PATH:/usr/local/hadoop/sbin
ENV PATH=$PATH:/usr/local/zookeeper/bin 

#RUN echo "hduser:123" | chpasswd

USER hduser
WORKDIR /home/hduser
RUN ssh-keygen -t rsa -P "" -f /home/hduser/.ssh/id_rsa && \
    cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys && \
    chmod 600 /home/hduser/.ssh/authorized_keys


COPY configurations/sshd_config /etc/ssh/sshd_config
COPY configurations/hadoop-env.sh configurations/yarn-site.xml configurations/core-site.xml configurations/mapred-site.xml configurations/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY configurations/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg
COPY configurations/workers /usr/local/hadoop/etc/hadoop/workers
COPY stscript.sh /home/hduser/
    
RUN sudo chmod +x /home/hduser/stscript.sh


ENTRYPOINT [ "./stscript.sh" ]

FROM hadoop AS hbase

ADD https://dlcdn.apache.org/hbase/stable/hbase-2.5.11-bin.tar.gz /usr/local
RUN sudo tar -xzf /usr/local/hbase-2.5.11-bin.tar.gz -C /usr/local && \
    sudo mv /usr/local/hbase-2.5.11 /usr/local/hbase && \
    sudo chown -R hduser:hadoop /usr/local/hbase && \
    sudo chmod -R 755 /usr/local/hbase && \
    sudo rm /usr/local/hbase-2.5.11-bin.tar.gz

COPY hbase_config/* /usr/local/hbase/conf/

ENV HBASE_HOME=/usr/local/hbase

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java' >> $HBASE_HOME/conf/hbase-env.sh && \
    echo 'export HBASE_MANAGES_ZK=false' >> $HBASE_HOME/conf/hbase-env.sh

