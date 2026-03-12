using System;

namespace ConsoleApp2
{
    internal class P3
    {
        static void Main()
        {
            Console.Write("Enter Name: ");
            string name = Console.ReadLine() ?? "";

            Console.Write("Enter Salary: ");
            double salary = Convert.ToDouble(Console.ReadLine());

            Console.Write("Enter Experience (years): ");
            int experience = Convert.ToInt32(Console.ReadLine());

            double bonusRate;
            if (experience < 2)
            {
                bonusRate = 0.05;
            }
            else if (experience <= 5)
            {
                bonusRate = 0.10;
            }
            else
            {
                bonusRate = 0.15;
            }
            double bonus = salary > 0 ? salary * bonusRate : 0;

            double finalSalary = salary + bonus;

            Console.WriteLine("\nEmployee: " + name);
            Console.WriteLine("Bonus: " + bonus.ToString("C"));
            Console.WriteLine("Final Salary: " + finalSalary.ToString("C"));
        }
    }
}

