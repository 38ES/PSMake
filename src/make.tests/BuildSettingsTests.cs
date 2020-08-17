using System;
using System.IO;
using Xunit;
using HoneyBadgers.Make;
using System.Collections;
using System.Management.Automation;

namespace make.tests
{
    public class BuildSettingsTests
    {
        Hashtable Hashtable;
        ScriptBlock BuildScriptBlock;
        ScriptBlock CleanScriptBlock;
        const string BuildScript = @"Write-Output 'Build Invoked'";
        const string CleanScript = @"Write-Output 'Clean Invoked'";
        

        public BuildSettingsTests()
        {
            Hashtable = new Hashtable();

            BuildScriptBlock = ScriptBlock.Create(BuildScript);
            CleanScriptBlock = ScriptBlock.Create(CleanScript);

            
        }

        [Fact]
        public void BuildSettings_ShouldBeValid()
        {
            InitializeTestModuleHashtable();
            BuildSettings.ValidateBuildSettings(Hashtable);            
        }

        
        [Theory]
        [ClassData(typeof(BadModuleNames))]
        public void BuildSettings_ShouldFailWithInvalidModuleName(string badName) {
            InitializeTestModuleHashtable();
            Hashtable["ModuleName"] = badName;
            Assert.Throws<InvalidDataException>(() => BuildSettings.ValidateBuildSettings(Hashtable));
        }

        [Theory]
        [InlineData("ModuleName")]
        [InlineData("Clean")]
        [InlineData("Build")]
        public void BuildSettings_ShouldFailWithNo(string parameterName) {
            InitializeTestModuleHashtable();
            Hashtable.Remove(parameterName);
            Assert.Throws<InvalidDataException>(() => BuildSettings.ValidateBuildSettings(Hashtable));
        }
        
        
        private void InitializeTestModuleHashtable() {
            Hashtable.Add("ModuleName", "TestModule");
            Hashtable.Add("Build", BuildScriptBlock);
            Hashtable.Add("Clean", CleanScriptBlock);

        }

        private void InitializeBadModuleName() {
            
        }
    }
}
