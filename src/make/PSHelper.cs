using System.Management.Automation;
using System;

namespace HoneyBadgers.Util
{
    public static class PSHelper
    {
        public static TType CastPSObject<TType>(object o) {
            if(o is PSObject obj) {
                return (TType)obj.BaseObject;
            } else {
                return (TType)o;
            }
        }

        public static void ThrowPSError(this PSCmdlet cmdlet, Exception exception, string errorId, ErrorCategory category, object target) {
            cmdlet.ThrowTerminatingError(
                new ErrorRecord(exception, errorId, category, target)
            );
        }

        
        public static TType CheckPSObjectType<TType>(object obj, Action onError) {
            TType output;
            if(!TryCastPSObject(obj, out output)) {
                onError();
            }
            return output;
        }

        public static bool TryCastPSObject<TType>(object obj, out TType output) {
            var realObj = obj is PSObject ? ((PSObject)obj).BaseObject : obj;

            if(realObj is TType tobj) {
                output = tobj;
                return true;
            } else {
                output = default(TType);
                return false;
            }
        } 
    }
}