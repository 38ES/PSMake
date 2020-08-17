using Xunit;

namespace make.tests
{
    public class BadModuleNames : TheoryData<string>
    {
        public BadModuleNames()
        {
            
            Add(string.Empty);
            Add(" ");
            Add("\t");
            Add("\r\n");
            Add("123Invalid");
            Add("(Bad)");
            Add("<Bad>");
            Add("StillB@d");
            
        }
    }
}