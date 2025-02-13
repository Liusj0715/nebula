# Copyright (c) 2021 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License.
Feature: Push Limit down project rule

  Background:
    Given a graph with space named "nba"

  Scenario: push limit down to Project
    When profiling query:
      """
      MATCH p=(v:player)-[]->(n)
      WHERE id(v)=="Tim Duncan" and n.age>30
      RETURN p LIMIT 100
      """
    Then the result should be, in any order:
      | p                                                                                                                                                                                                                                 |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:teammate@0 {end_year: 2016, start_year: 2010}]->("Danny Green" :player{age: 31, name: "Danny Green"})>             |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:teammate@0 {end_year: 2016, start_year: 2015}]->("LaMarcus Aldridge" :player{age: 33, name: "LaMarcus Aldridge"})> |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:teammate@0 {end_year: 2016, start_year: 2002}]->("Manu Ginobili" :player{age: 41, name: "Manu Ginobili"})>         |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:teammate@0 {end_year: 2016, start_year: 2001}]->("Tony Parker" :player{age: 36, name: "Tony Parker"})>             |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:like@0 {likeness: 95}]->("Manu Ginobili" :player{age: 41, name: "Manu Ginobili"})>                                 |
      | <("Tim Duncan" :bachelor{name: "Tim Duncan", speciality: "psychology"} :player{age: 42, name: "Tim Duncan"})-[:like@0 {likeness: 95}]->("Tony Parker" :player{age: 36, name: "Tony Parker"})>                                     |
    And the execution plan should be:
      | id | name         | dependencies | operator info |
      | 18 | DataCollect  | 26           |               |
      | 26 | Project      | 25           |               |
      | 25 | Limit        | 20           |               |
      | 20 | Filter       | 13           |               |
      | 13 | Project      | 12           |               |
      | 12 | InnerJoin    | 11           |               |
      | 11 | Project      | 22           |               |
      | 22 | GetVertices  | 7            |               |
      | 7  | Filter       | 6            |               |
      | 6  | Project      | 5            |               |
      | 5  | Filter       | 24           |               |
      | 24 | GetNeighbors | 1            |               |
      | 1  | PassThrough  | 0            |               |
      | 0  | Start        |              |               |
