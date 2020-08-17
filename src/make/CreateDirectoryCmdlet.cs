using System;
using System.Management.Automation;
using System.Collections;
using System.IO;
using HoneyBadgers.Util;

namespace HoneyBadgers.Make
{
    [Cmdlet(VerbsLifecycle.Invoke, "CreateDirectory")]
    [Alias("CreateDirectory")]
    public class CreateDirectoryCmdlet : PSCmdlet
    {
        private Hashtable Settings { get; set; }

        [Parameter(Position = 0, Mandatory = true)]
        public ScriptBlock ScriptBlock { get; set; }

        [Parameter]
        public string In { get; set; }

        public CreateDirectoryCmdlet() : base()
        {
            
        }

        protected override void BeginProcessing() {
            this.Settings = PSHelper.CastPSObject<Hashtable>(this.SessionState.PSVariable.GetValue("settings"));
            this.In = this.In ?? PSHelper.CastPSObject<string>(this.Settings["OutputModulePath"]);
            Environment.CurrentDirectory = this.SessionState.Path.CurrentFileSystemLocation.Path;
        }

        protected override void ProcessRecord() {
            
            foreach(var item in this.ScriptBlock.Invoke()) {
                if(item.BaseObject is string Path) {
                    var info = new DirectoryInfo(Path);
                    if(!info.Exists) { info.Create(); }
                } else if(item.BaseObject is DirectoryInfo info) {
                    if(!info.Exists) { info.Create(); }
                } else {
                    WriteError(
                        new ErrorRecord(
                            new InvalidDataException($"Expected either string or DirectoryInfo, but received {item.BaseObject.GetType()}"),
                            "InvalidData",
                            ErrorCategory.InvalidData,
                            item
                        )
                    );
                }
            }
        }
    }
}