using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Migrator
{
    class Program
    {
        static void Main(string[] args)
        {
            var migrator = new DotNetAppSqlDbMigrator(new DebugMigrationsLogger());
            migrator.Migrations.Update();
        }
    }
}
