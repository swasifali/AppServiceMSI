using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.Migrations;
using System.Data.Entity.Migrations.Infrastructure;
using DotNetAppSqlDb.DataAccess.Migrations;

namespace Migrator
{
    public class DotNetAppSqlDbMigrator
    {
        private readonly MigratorLoggingDecorator _migrator;

        public MigratorLoggingDecorator Migrations
        {
            get
            {
                return _migrator;
            }
        }

        public DotNetAppSqlDbMigrator(MigrationsLogger logger)
        {
            var configuration = new Configuration() { ContextKey = "DotNetAppSqlDb.DataAccess.Migrations.Configuration" }; 
            _migrator = new MigratorLoggingDecorator(new DbMigrator(configuration), logger);
        }
    }
}
