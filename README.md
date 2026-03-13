# Tier 1 Deployment Runbook: Perception & Grounding

This document outlines the initialization sequence for Tier 1 of the local-first Neuro-Symbolic Optimization Engine.

## 1. Python Environment Setup
Execute the following commands in a Windows terminal to initialize the environment and install required dependencies:

```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

## 2. Neo4j Substrate Instantiation
Launch the offline graph database substrate using the following Docker execution command:

```powershell
docker run --hostname=fec1db78411d --env=NEO4J_AUTH=none --env=PATH=/var/lib/neo4j/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin --env=JAVA_HOME=/opt/java/openjdk --env=NEO4J_SHA256=4e95626e21348a30109799a44639c2169bc24e27e1a1371972ff2583c3d8493c --env=NEO4J_TARBALL=neo4j-community-2026.02.2-unix.tar.gz --env=NEO4J_EDITION=community --env=NEO4J_HOME=/var/lib/neo4j --env=LANG=C.UTF-8 --volume=/data --volume=/logs --network=bridge --workdir=/var/lib/neo4j -p 7474:7474 -p 7687:7687 --restart=no --runtime=runc -d neo4j:latest
```

## 3. Topological Compilation
To physically compile the Directed Acyclic Graph (DAG), follow these steps:

1. Log into the local Neo4j instance at [http://localhost:7474](http://localhost:7474).
2. Use the password `Mood4Food` if prompted.
3. Sequentially paste and execute the contents of the following files in the Neo4j Browser:
   - `neo4j_schema_part1.cypher`
   - `neo4j_schema_part2.cypher`
   - Any provided ontology patches.

## 4. Pipeline Execution
Launch the localized testing UI to evaluate deterministic safety pruning:

```powershell
streamlit run tier_1_demo.py
```
