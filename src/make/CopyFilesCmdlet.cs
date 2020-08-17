using System.Management.Automation;
using HoneyBadgers.Util;
using System.Collections;
using System.IO;

namespace HoneyBadgers.Make
{
    [Cmdlet(VerbsLifecycle.Invoke, "CopyFiles")]
    [Alias("CopyFiles")]
    public class CopyFilesCmdlet : PSCmdlet
    {
        private Hashtable Settings { get; set; }

        [Parameter(Position = 0, Mandatory = true)]
        public ScriptBlock ScriptBlock { get; set; }


        [Parameter]
        public string To { get; set; }

        private DirectoryInfo ToDir { get; set; }

        protected override void BeginProcessing() {
            this.Settings = PSHelper.CastPSObject<Hashtable>(this.SessionState.PSVariable.GetValue("settings"));
            this.To = string.IsNullOrWhiteSpace(To) ? PSHelper.CastPSObject<string>(Settings["OutputModulePath"]) : To;
            this.ToDir = new DirectoryInfo(To);

            if(!ToDir.Exists) { ToDir.Create(); }
        }

        protected override void ProcessRecord() {
            foreach(var item in ScriptBlock.Invoke()) {
                if(item.BaseObject is string path) {
                    foreach(var fileObj in this.InvokeProvider.ChildItem.Get(path, false)) {
                        var file = PSHelper.CastPSObject<FileInfo>(fileObj.BaseObject);
                        File.Copy(file.FullName, Path.Combine(ToDir.FullName, file.Name));
                    }
                } else if(item.BaseObject is FileInfo file) {
                    File.Copy(file.FullName, Path.Combine(ToDir.FullName, file.Name));
                } else {
                    WriteError(
                        new ErrorRecord(
                            new InvalidDataException($"Expected either string or FileInfo, but received {item.BaseObject.GetType()}"),
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