# HBase on Hadoop Cluster with Docker Compose

This project provides a multi-node HBase cluster running on top of a highly available Hadoop HDFS setup, all orchestrated with Docker Compose. It is designed for development, testing, and learning purposes.

## Cluster Architecture

- **Hadoop Masters (NameNodes & JournalNodes & ZooKeeper):**
    - `master1`, `master2`, `master3`: Each acts as a NameNode, JournalNode, and ZooKeeper node for HDFS High Availability.
- **HBase Masters:**
    - `hmaster1`, `hmaster2`: HBase Master nodes for high availability.
- **HBase RegionServers:**
    - `regionserver1`, `regionserver2`, `regionserver3`: Handle HBase data storage and requests.

All services are connected via a custom Docker network (`hd_net`). Persistent data is stored in Docker volumes.


## Volumes

Persistent storage is provided for NameNodes, JournalNodes, DataNodes, and ZooKeeper nodes.

## Usage

1. **Build and Start the Cluster:**
     ```sh
     docker-compose up --build
     ```

2. **Access Web UIs:**
     - HDFS NameNode: [http://localhost:9885](http://localhost:9885)
     - HBase Master: [http://localhost:16010](http://localhost:16010)

3. **Stop the Cluster:**
     ```sh
     docker-compose down
     ```

## Notes

- All services depend on healthy Hadoop masters before starting HBase components.
- The cluster is suitable for experimentation and development, not for production use.

