using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using Microsoft.Azure.Services.AppAuthentication;

namespace DotNetAppSqlDb.Models
{
    public class MyDatabaseContext : DbContext
    {
        // You can add custom code to this file. Changes will not be overwritten.
        // 
        // If you want Entity Framework to drop and regenerate your database
        // automatically whenever you change your model schema, please use data migrations.
        // For more information refer to the documentation:
        // http://msdn.microsoft.com/en-us/data/jj591621.aspx
    
        public MyDatabaseContext() : base("name=MyDbConnection")
        {
        }

        public MyDatabaseContext(SqlConnection conn) : base(conn, true)
        {
            conn.ConnectionString = WebConfigurationManager.ConnectionStrings["MyDbConnection"].ConnectionString;
            // DataSource != LocalDB means app is running in Azure with the SQLDB connection string you configured
            if (Convert.ToBoolean(ConfigurationManager.AppSettings["UseMSI"]))
                conn.AccessToken = (new AzureServiceTokenProvider()).GetAccessTokenAsync("https://database.windows.net/").Result;

            Database.SetInitializer<MyDatabaseContext>(null);
        }

        public System.Data.Entity.DbSet<DotNetAppSqlDb.Models.Todo> Todoes { get; set; }
    }
}
