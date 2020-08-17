using System.Collections;
using System.Management.Automation;
using System;
using System.IO;
using System.Text.RegularExpressions;
using HoneyBadgers.Util;

namespace HoneyBadgers.Make
{
    public static class BuildSettings
    {
        public static void ValidateBuildSettings(Hashtable settings) {
            
            if(!settings.ContainsKey("ModuleName")) { throw new InvalidDataException("Required Property 'ModuleName' is not defined."); }
            
            if(!Regex.IsMatch(
                PSHelper.CastPSObject<string>(settings["ModuleName"]),
                "^[a-zA-Z][a-zA-Z0-9]*$"
            )) {
                throw new InvalidDataException($"Property 'ModuleName' ({settings["ModuleName"]}) is invalid.");
            }

            // Check for Build scriptblock
            if(!settings.ContainsKey("Build")) { throw new InvalidDataException("Required Property 'Build' is not defined"); }
            object build = settings["Build"] is PSObject ? ((PSObject)settings["Build"]).BaseObject : settings["Build"];
            if(!(build is ScriptBlock)) { throw new InvalidDataException($"Property Build is not a scriptblock! ({build})"); }
    
            // Check for Clean scriptblock
            if(!settings.ContainsKey("Clean")) { throw new InvalidDataException("Required Property 'Clean' is not defined"); }
            object clean = settings["Clean"] is PSObject ? ((PSObject)settings["Clean"]).BaseObject : settings["Clean"];
            if(!(clean is ScriptBlock)) { throw new InvalidDataException($"Property Clean is not a scriptblock! ({clean})"); }
        }
    }
}