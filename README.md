# RAD

## Overview

This is an application which purpose is to help organizations, companies, or work teams create an administration system (i.e. intranet, or internal system) without the need of implementing a UI themselves. It makes it possible to store application logic in the form of SQL queries, and then execute them in a controlled way, by specifying which users can create, publish and execute queries, which databases can be used (test, staging, production, etc.) and keep an execution log or history.

To summarize, it works as a usual SQL client, but with teamwork capabilities.

RAD (meaning Rapid Application Development) is a temporary name.

## Specifications

### Company account

A company account is registered, and multiple users can be added (through e-mail invitations) to it. These users are the company staff or team members.

In each company account, projects can be created, and these projects have a different configuration each. This configuration involves database connections, permissions, and other attributes.

### User permissions

Users may have one or multiple permissions. These are:

**Execution permission:** Can execute queries.
**Develop permission:** Can create new queries. Usually, an engineer/developer. A person with this permission cannot publish them (they remain hidden).
**Publish permission:** Can publish queries that were initially developed but not published. Usually, a manager or someone who does code reviews would have this permission.

### Database connections

Add connections that point to your databases. This involves entering the hostname, username, password, and other relevant data. Since the philosophy of this application is to keep it simple and flexible, if you want to limit access to your databases, you should create new database users, and limit their access by granting fewer read/write permissions, and then use those users inside the app.

### Database connection permission

It's possible to configure who can use which database connections. This makes it useful for assigning a test/staging database to developers, and the production database for actual users.

### Views

Inside each project, views can be created. A view is simply a screen that contains multiple queries inside.

In general, the queries inside a view should be grouped in a way that makes sense (i.e. are related). However, there is no need to follow this convention, and the user can structure their business logic the way they want. They may separate the logic in several projects, or have one project with many views. The configuration depends on the user's needs.

### Query

Inside a view, one or multiple queries can be created. Each query allows the creation of a form (for user input) and also the creation of a SQL code, which is version-controlled. Once the user executes the query, the user input will be replaced in it, generating the final SQL string, which will be sent to the database server. Data will then be fetched and displayed on the screen.

### Other features

* Configure a query to be periodically executed, and have the result be delivered to one or multiple users e-mails.
* For each query, create a form (text, number, checkbox, etc.) that allows the executor user to configure how the query will be executed (e.g. fetch students where age is greater than X, and have X as a number input).

## Technologies used

* React.js (with Redux)
* Ruby on Rails
* Postgres
* WebSockets
* Redis
* Bootstrap
* Others

## Issues

This project is a work in progress. This document contains the specifications of what is to be implemented. Most of these specifications are implemented, however not functioning perfectly (there are unhandled edge cases, bugs, and other issues). There are still many technical difficulties that are yet to be sorted out.

Perhaps the biggest issue is deciding how to deploy this application. If it's deployed as a SaaS, there would be a massive problem communicating with the client's database. If it's an open source (free) application, then the client can deploy it in their network, and it'd be much easier to make it work.

A SaaS would require an extremely high amount of storage, but might be doable depending on the number of clients, and the amount of data they have.
