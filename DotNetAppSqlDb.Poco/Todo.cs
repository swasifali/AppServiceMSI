using System;
using System.ComponentModel.DataAnnotations;

namespace DotNetAppSqlDb.Poco
{
    public class Todo
    {
        public int ID { get; set; }
        public string Description { get; set; }

        [Display(Name = "Created Date")]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime CreatedDate { get; set; }

        public bool Done { get; set; }

        //To test migrations uncheck and execute Add-Migration
        //[Display(Name = "Assigned To")]
        //public string AssginedTo{ get; set; }
    }
}