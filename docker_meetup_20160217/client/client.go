package main

import (
    "fmt"
    "time"
    "github.com/gocql/gocql"
)

func main() {

    var clustername string = "cassandra"
    var keyspace string = "demo"

    fmt.Println("Setting cluster to", clustername)
    cluster := gocql.NewCluster(clustername)

    fmt.Println("Setting keyspace to", keyspace)
    cluster.Keyspace = keyspace

    cluster.Consistency = gocql.Quorum
    cluster.Timeout = 1 * time.Minute
    cluster.RetryPolicy = &gocql.SimpleRetryPolicy{NumRetries: 10}

    fmt.Println("Creating session.")
    session, _ := cluster.CreateSession()
    defer session.Close()

    var firstname string
    var lastname string
    var table string

    i := 0
    for 42 == 42 {

      if err := session.Query(`select columnfamily_name from System.schema_columnfamilies where columnfamily_name = 'persons' ALLOW FILTERING`).Consistency(gocql.One).Scan(&table); err != nil {
        fmt.Println("Table not found. No panic.")
      } else {
        if err := session.Query(`SELECT firstname, lastname FROM persons`).Consistency(gocql.One).Scan(&firstname, &lastname); err != nil {
          fmt.Println("No data found. No panic.")
        }
          fmt.Println(i, ":", "Person is", firstname, lastname)
          i++
        }

   time.Sleep(1000 * time.Millisecond)

   }
}
