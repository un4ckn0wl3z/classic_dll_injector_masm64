#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

extern "C" bool InjectDll(uint32_t pid, const char* dllPath);

int main(int argc, const char* argv[])
{
	if (argc < 3)
	{
		printf("Usage: %s <pid> <dll_path>\n", argv[0]);
		return 0;
	}

	auto injected = InjectDll(atoi(argv[1]), argv[2]);
	if (!injected)
	{
		printf("Failed inject!\n");
		return 1;
	}

	printf("Success inject!\n");
	return 0;

}