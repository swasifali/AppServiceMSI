using System;
using System.Data.Entity.Migrations.Infrastructure;
using System.Diagnostics;

namespace Migrator
{
    public class DebugMigrationsLogger : MigrationsLogger
    {
        public override void Info(string message)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Debug.WriteLine(message);
            Console.WriteLine(message);
            Console.ResetColor();
        }

        public override void Verbose(string message)
        {
            Debug.WriteLine(message);
            Console.WriteLine(message);
        }

        public override void Warning(string message)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Debug.WriteLine("WARNING: " + message);
            Console.WriteLine("WARNING: " + message);
            Console.ResetColor();
        }

        public void Error(string message)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Debug.WriteLine("ERROR: " + message);
            Console.WriteLine("ERROR: " + message);
            Console.ResetColor();
        }
    }
}
