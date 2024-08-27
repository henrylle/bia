using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BIA.Models
{
    [Table("Tarefas")]
    public class Tarefa
    {
        [Key]
        [Column("uuid")]
        [Display(Name = "Código")]
        public Guid Id { get; set; }

        [Column("dia_atividade")]
        [Display(Name = "Dia_atividade")]
        public string Dia_atividade { get; set; }

        [Column("titulo")]
        [Display(Name = "Titulo")]
        public string Titulo { get; set; }


        [Column("importante")]
        [Display(Name = "Importante")]
        public Boolean Importante { get; set; }

        [Column("createdAt")]
        [Display(Name = "createdAt")]
        public DateTime createdAt { get; set; }


        [Column("updatedAt")]
        [Display(Name = "updatedAt")]
        public DateTime updatedAt { get; set; }
    }


}
