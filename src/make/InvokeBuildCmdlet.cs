using System.Management.Automation;
using System;
using System.IO;
using HoneyBadgers.Util;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;

namespace HoneyBadgers.Make
{
    [Cmdlet(VerbsLifecycle.Invoke, "Build")]
    [Alias("make")]
    public class InvokeBuildCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        [ValidateSet("","build","clean", "test", "template","publish")]
        public string Command { get; set; } = "build";

        [Parameter(ValueFromRemainingArguments = true)]
        public List<object> Remaining { get; set; }

        private FileInfo Template { get; set; }

        protected override void BeginProcessing() {
            WriteDebug("Start Begin");
            Environment.CurrentDirectory = this.SessionState.Path.CurrentFileSystemLocation.Path;
            var modulePath = this.MyInvocation.MyCommand.Module.ModuleBase;
            Template = new FileInfo(Path.Combine(modulePath, "template.psd1"));

             if(!Template.Exists) { 
                 ThrowTerminatingError(
                     new ErrorRecord(
                         new FileNotFoundException(
                             $"File '{Template.FullName}' not found!"
                         ),
                         "FileNotFound",
                         ErrorCategory.ReadError,
                         Template
                     )
                );
             }
             WriteDebug("End Begin");
        }

        protected override void ProcessRecord() {
            switch(Command) {
                case "template":
                    WriteVerbose("template executing");
                    WriteDebug($"Remaining parameters:\r\n{string.Join("\r\n", Remaining)}");
                    MakeTemplate();
                    break;
                case "":
                case "build":
                    MakeBuild();
                    break;
                case "clean":
                    MakeClean();
                    break;
                case "test":
                    MakeTest();
                    break;
                case "publish":
                    MakePublish();
                    break;
                default:
                    this.ThrowPSError(
                        new ArgumentException($"Unsupported command '{Command}'", nameof(Command), null),
                        "InvalidCommand",
                        ErrorCategory.SyntaxError,
                        Command
                    );
                    break;

            }
        }

        private void MakeTemplate() {
            
            var moduleName = PSHelper.CastPSObject<string>(Remaining[0]);
            var moduleDirectory = new DirectoryInfo(Path.Combine(".",moduleName));
            var functionsDirectory = new DirectoryInfo(Path.Combine(moduleDirectory.FullName, "functions"));
            var testsDirectory = new DirectoryInfo(Path.Combine(moduleDirectory.FullName, "tests"));
            var moduleFile = new FileInfo(Path.Combine(moduleDirectory.FullName, Path.ChangeExtension(moduleName, "psm1")));
            var buildFile = new FileInfo(Path.Combine(moduleDirectory.FullName, "build.psd1"));

            if(!moduleDirectory.Exists) moduleDirectory.Create();
            if(!functionsDirectory.Exists) functionsDirectory.Create();
            if(!testsDirectory.Exists) testsDirectory.Create();
            
            CheckNotExistsOrOverwritable(moduleFile);
            CheckNotExistsOrOverwritable(buildFile);

            File.WriteAllLines(
                moduleFile.FullName,
                new string[] {
                    @"Get-ChildItem $PSScriptRoot\functions\ -File -Recurse | ForEach-Object { . $_.FullName }"
                }
            );
            
            File.WriteAllText(
                buildFile.FullName,
                File.ReadAllText(Template.FullName)
                    .Replace("%%MODULENAME%%", moduleName)
            );
        }

        private void MakeBuild() {
            var buildData = ImportBuildFile();
                    
            var outputDirectory = PSHelper.CastPSObject<string>(buildData["OutputDirectory"]);
            var buildDir = new DirectoryInfo(outputDirectory);

            if(!buildDir.Exists) { buildDir.Create(); }

            ExecuteCommand(Command, buildData);

            WriteVerbose("build executing");
        }

        private void MakeClean() {
            ExecuteCommand(Command, ImportBuildFile());
        }

        private void MakePublish() {
            ExecuteCommand(Command, ImportBuildFile());
        }

        private void MakeTest() {
            ExecuteCommand(Command, ImportBuildFile());
        }

        private void ExecuteCommand(string command, Hashtable buildData) {
            if(!buildData.ContainsKey(Command)) { 
                this.ThrowPSError(
                    new InvalidDataException($"Build file does not contain '{Command}' scriptblock."),
                    "PropertyNotFound",
                    ErrorCategory.NotImplemented,
                    buildData
                );
            }
            
            var wrappedScriptBlock = PSHelper.CheckPSObjectType<ScriptBlock>(buildData[command], onError: () => this.ThrowPSError(
                new InvalidDataException($"Build file property '{Command}' not a scriptblock!"),
                "UnexpectedPropertyType",
                ErrorCategory.InvalidData,
                buildData[command]
            ));
            var scriptblock = PSHelper.CastPSObject<ScriptBlock>(wrappedScriptBlock.Invoke()[0]);
            scriptblock.InvokeWithContext(null, new List<PSVariable>() { new PSVariable("settings", SettingsFromBuildData(buildData)) }, null);
        }

        private Hashtable ImportBuildFile() {
            var output = this.InvokeCommand.InvokeScript(@"Get-BuildSettings .\build.psd1");
            return PSHelper.CheckPSObjectType<Hashtable>(output[0], () => this.ThrowPSError(
                    new InvalidDataException($"Expected Hashtable returned from Get-BuildSettings, but was {output[0].GetType()}"),
                    "InvalidData",
                    ErrorCategory.InvalidData,
                    output[0]

                )
            );
            
        }

        private Hashtable SettingsFromBuildData(Hashtable buildFile) {
            var settings = new Hashtable();
            var ignoreProperties = new string[] { "build", "clean", "test", "template", "publish" };
            foreach(var key in buildFile.Keys) {
                if(!ignoreProperties.Contains((string)key, StringComparer.InvariantCultureIgnoreCase)) {
                    settings.Add(key, buildFile[key]);
                }
            }
            return settings;
        }

        private void CheckNotExistsOrOverwritable(FileInfo file) {
            if(file.Exists && !ShouldContinue(
                $"File '{file.FullName}' already exists. Are you sure you want to overwrite?",
                "Overwrite File"
            )) {
                ThrowTerminatingError(
                    new ErrorRecord(
                        new IOException($"File '{file.FullName}' already exists."),
                        "FileAlreadyExists",
                        ErrorCategory.WriteError,
                        file
                    )
                );
            }
        }

    }
}