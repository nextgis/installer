#include <windows.h>
// CODED By KiKoLo Software, ltd.
#include "exdll.h"

HINSTANCE g_hInstance;

HWND g_hwndParent;

void __declspec(dllexport) SetEnvVar(HWND hwndParent, int string_size,
                                      char *variables, stack_t **stacktop)
{
	char var_name[1024];
	char var_value[1024];

   EXDLL_INIT();

   popstring(var_name);
   popstring(var_value);
	
	SetEnvironmentVariableA(var_name,var_value);

	pushstring(NULL);
}



BOOL WINAPI _DllMainCRTStartup(HANDLE hInst, ULONG ul_reason_for_call, LPVOID lpReserved)
{
  g_hInstance=hInst;
   return TRUE;
}
