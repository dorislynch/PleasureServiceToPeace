using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Pleasure.Service.To.Peace.RNPleasureServiceToPeace
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNPleasureServiceToPeaceModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNPleasureServiceToPeaceModule"/>.
        /// </summary>
        internal RNPleasureServiceToPeaceModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNPleasureServiceToPeace";
            }
        }
    }
}
