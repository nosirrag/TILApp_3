//import FluentSQLite
import FluentPostgreSQL
import Vapor

/// Places to Check for local database setup
//https://docs.vapor.codes/3.0/fluent/getting-started/
//https://github.com/vapor-community/postgresql

//https://forums.raywenderlich.com/t/chapter-6-postgresql/41740

//https://medium.com/@johannkerr/persisting-data-with-vapor-3-and-postgresql-246386ac1448
//https://medium.com/@martinlasek/tutorial-how-to-use-postgresql-efb62a434cc5
//https://github.com/vapor-community/postgresql-provider

//https://theswiftwebdeveloper.com/diving-into-vapor-part-1-up-and-running-with-vapor-3-edab3c79aab9
//https://theswiftwebdeveloper.com/diving-into-vapor-part-2-persisting-data-in-vapor-3-c927638301e8
//https://theswiftwebdeveloper.com/diving-into-vapor-part-3-introduction-to-routing-and-fluent-in-vapor-3-221d209f1fec
//https://github.com/calebkleveter/chatter/tree/basic-routing-and-fluent

///https://theswiftdev.com/2018/04/09/vapor-3-tutorial-for-beginners/

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    // 2
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    // 1
    var databases = DatabasesConfig()
    // 2
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "garrisonjazz"
    let databaseName = Environment.get("DATABASE_DB") ?? "shapeshifterlab"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    // 3
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        port: 5432,
        username: username,
        database: databaseName
        //password: password
    )
//    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", username: "garrisonjazz", database: "shapeshifterlab")
    // 4
    let database = PostgreSQLDatabase(config: databaseConfig)
    // 5
    databases.add(database: database, as: .psql)
    // 6
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
}
