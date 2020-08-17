using System.Management.Automation;
using System.IO;
using HoneyBadgers.Util;
using System.Collections;
using System;

namespace HoneyBadgers.Make {

    [Cmdlet(VerbsCommon.Get, "BuildSettings")]
    public class GetBuildSettingsCmdlet : PSCmdlet {

        [Parameter(Mandatory = true, Position = 0)]
        public string BuildFilePath { get; set; }

        private string DefaultConfigFilePath { get; set; }

        protected override void BeginProcessing() {
            DefaultConfigFilePath = Path.Combine(this.MyInvocation.MyCommand.Module.ModuleBase, "defaultsettings.psd1");
            Environment.CurrentDirectory = this.SessionState.Path.CurrentFileSystemLocation.Path;
        }

        protected override void ProcessRecord() {
            
            var buildInfo = new FileInfo(this.BuildFilePath);
            if(!buildInfo.Exists) {
                ThrowTerminatingError(
                    new ErrorRecord(
                        new FileNotFoundException(
                            $"File '{this.BuildFilePath}' not found!"
                        ),
                        "FileNotFound",
                        ErrorCategory.InvalidArgument,
                        this.BuildFilePath
                    )
                );
            }
            
            

            var buildRaw = this.InvokeCommand.InvokeScript($"Import-PowershellDataFile '{buildInfo.FullName}'");
            if(buildRaw.Count < 1) {
                ThrowTerminatingError(
                    new ErrorRecord(
                        new InvalidDataException("Unable to import build file!"),
                        "UnableToImport",
                        ErrorCategory.InvalidResult,
                        buildRaw
                    )
                );
            }
            var buildConfig = PSHelper.CastPSObject<Hashtable>(buildRaw[0]);
            
            var defaultInfo = new FileInfo(this.DefaultConfigFilePath);
            if(!defaultInfo.Exists) { 
                ThrowTerminatingError(
                    new ErrorRecord(
                        new FileNotFoundException(
                            $"File '{this.DefaultConfigFilePath}' not found!"
                        ),
                        "FileNotFound",
                        ErrorCategory.InvalidArgument,
                        this.DefaultConfigFilePath
                    )
                );
            }

            var defaultRaw = this.InvokeCommand.InvokeScript($"Import-PowerShellDataFile '{defaultInfo.FullName}'");
            if(defaultRaw.Count < 1) {
                ThrowTerminatingError(
                    new ErrorRecord(
                        new InvalidDataException($"Unable to import default build configuration - {this.DefaultConfigFilePath}"),
                        "UnableToImport",
                        ErrorCategory.InvalidResult,
                        defaultRaw
                    )
                );
            }

            var defaultConfig = PSHelper.CastPSObject<Hashtable>(defaultRaw[0]);

            foreach (var key in buildConfig.Keys)
            {
                if(defaultConfig.ContainsKey(key)) {
                    defaultConfig[key] = buildConfig[key];
                } else {
                    defaultConfig.Add(key, buildConfig[key]);
                }
            }
            if(!defaultConfig.ContainsKey("OutputModulePath")) {
                defaultConfig.Add("OutputModulePath",
                    Path.Combine(
                        PSHelper.CastPSObject<string>(defaultConfig["OutputDirectory"]),
                        PSHelper.CastPSObject<string>(defaultConfig["ModuleName"])
                    )
                );
            }

            BuildSettings.ValidateBuildSettings(defaultConfig);
            WriteObject(defaultConfig);
        }

    }
}