using System;
using System.Management.Automation;
using System.Collections;
using System.IO;
using System.Text;
using System.Linq;
using HoneyBadgers.Util;

namespace HoneyBadgers.Make
{
    [Cmdlet(VerbsLifecycle.Invoke, "Collate")]
    [Alias("Collate")]
    public class CollateCmdlet : PSCmdlet
    {
        private Hashtable Settings { get; set; }

        [Parameter(Position = 0, Mandatory=true)]
        public ScriptBlock ScriptBlock { get; set; }

        [Parameter]
        public string OutputDirectory { get; set; }

        [Parameter]
        public string FileName { get; set; }

        private FileInfo OutputFile { get; set; }

        public CollateCmdlet() : base()
        {
            
        }

        protected override void BeginProcessing() {
            Environment.CurrentDirectory = this.SessionState.Path.CurrentFileSystemLocation.Path;

            this.Settings = PSHelper.CastPSObject<Hashtable>(this.SessionState.PSVariable.GetValue("settings"));
            this.OutputDirectory = this.OutputDirectory ?? PSHelper.CastPSObject<string>(this.Settings["OutputModulePath"]);
            this.FileName = this.FileName ?? $"{PSHelper.CastPSObject<string>(this.Settings["ModuleName"])}.psm1";

            this.OutputFile = new FileInfo(Path.Combine(OutputDirectory, FileName));
            var outputdir = new DirectoryInfo(OutputDirectory);

            if(!outputdir.Exists) { outputdir.Create(); }
            
        }
        protected override void ProcessRecord() {
            
            WriteDebug("Collate - Process Start");
            foreach(var item in ScriptBlock.Invoke()) {
                WriteDebug($"Collate, Item: {item}");
                if(item.BaseObject is string path ) {
                    // Item returned is a string (path) to a file
                    var files = this.InvokeProvider.ChildItem.Get(path, false)
                        .Select(t => t.BaseObject)
                        .Cast<FileInfo>();

                    foreach(var file in files) {
                        File.AppendAllText(this.OutputFile.FullName, $". ([scriptblock]::Create(@'\r\n{File.ReadAllText(file.FullName)}\r\n'@))\r\n", Encoding.UTF8);
                    }    
                    
                } else if(item.BaseObject is FileInfo currentFile) {
                    File.AppendAllText(this.OutputFile.FullName, $". ([scriptblock]::Create(@'\r\n{File.ReadAllText(currentFile.FullName)}\r\n'@))\r\n", Encoding.UTF8);
                } else {
                    WriteError(
                        new ErrorRecord(
                            new InvalidDataException(
                                $"Returned object ({item.BaseObject}) of type {item.BaseObject.GetType()} unexpected."
                            ),
                             "InvalidType", ErrorCategory.InvalidData, item));
                }

            }
        }
    }
}
