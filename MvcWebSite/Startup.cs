using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(MvcWebSite.Startup))]
namespace MvcWebSite
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
