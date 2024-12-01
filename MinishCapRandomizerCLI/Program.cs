﻿using RandomizerCore.Controllers;

namespace MinishCapRandomizerCLI;

internal class Program
{
    //Not Null
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
    private static Dictionary<string, Action> _commands;
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
    private static bool _exiting = false;
    
    private static void Main(string[] args)
    {
        GenericCommands.ShufflerController = new ShufflerController();
        GenericCommands.YamlController = new YamlController();
        Console.Write("Loading default logic file...");
        GenericCommands.ShufflerController.LoadLogicFile();
        GenericCommands.YamlController.LoadLogicFile();
        Console.WriteLine("done");
        if (args.Length == 1)
        {
            Console.WriteLine("Parsing provided commands file!");
            CommandFileParser.ParseCommandsFile(args[0]);
        }
        else
        {
            LoadCommands();
            InputLoop();
        }
    }

    private static void InputLoop()
    {
        PrintCommands();
        Helpers.CheckForUpdates();
        while (!_exiting)
        {
            Console.Write("Waiting for command, type \"Help\" to see the list of available commands: ");
            var command = Console.ReadLine();
            if (string.IsNullOrEmpty(command) || !_commands.ContainsKey(command))
            {
                GenericCommands.PrintError($"Invalid command entered! {command} is not a valid command!");
                continue;
            }
            
            _commands[command].Invoke();
        }
    }

    private static void LoadCommands()
    {
        _commands = new Dictionary<string, Action>
        {
            {"Help", PrintCommands},
            {"LoadRom", LoadRom},
            {"ChangeSeed", Seed},
            {"LoadLogic", LoadLogic},
            {"LoadPatch", LoadPatch},
            {"ClearYAML", ClearYAML},
            {"UseYAML", UseYAML},
            {"LoadYAML", LoadYAML},
            {"LoadSettings", LoadSettings},
            {"Options", Options},
            {"Logging", Logging},
            {"Randomize", Randomize},
            {"SaveRom", SaveRom},
            {"SaveSpoiler", SaveSpoiler},
            {"SavePatch", SavePatch},
            {"SaveHash", SaveHash},
            {"GetSettingString", GetSettingString},
            {"GetFinalSettingString", GetFinalSettingString},
            {"PatchRom", PatchRom},
            {"CreatePatch", CreatePatch},
            {"Exit", Exit},
            {"Strict", GenericCommands.Strict},
        };
    }

    private static void PrintCommands()
    {
        Console.WriteLine(@"Available Commands, note that commands are case-sensitive!
LoadRom                 Load a European Minish Cap ROM
ChangeSeed              Change randomization seed
LoadLogic               Load custom logic file
LoadPatch               Load custom patch file
ClearYAML               Clears the cached YAML options and resets all logic options to defaults
LoadYAML                Load YAML file to use as a Preset, replaces the selected options
UseYAML                 Use YAML file to use as a Preset or Mystery weights, instead of using the selected options
LoadSettings            Load a setting string, replaces the selected options
Options                 Display options, allows editing of option values
Logging                 Allows you to change logger settings
Randomize               Generates a randomized ROM
SaveRom                 Saves and patches the ROM, requires Randomize to have been called
SaveSpoiler             Saves the spoiler log, requires Randomize to have been called
SavePatch               Saves a BPS patch for the randomized ROM, requires Randomize to have been called
SaveHash                Saves a .png of the hash for the generated seed, requires Randomize to have been called
GetSettingString        Gets the setting string for your currently selected settings
GetFinalSettingString   Gets the setting string for the settings used for the randomized ROM, requires Randomize to have been called
PatchRom                Patches a European Minish Cap ROM with a BPS patch
CreatePatch             Creates a patch from a patched ROM and an unpatched European Minish Cap ROM
Exit                    Exits the program
Strict                  Toggle strict mode (exit after error)
");
    }

    private static void LoadRom()
    {
        GenericCommands.LoadRom();
    }

    private static void Seed()
    {
        GenericCommands.Seed();
    }

    private static void LoadLogic()
    {
        GenericCommands.LoadLogic();
    }

    private static void LoadPatch()
    {
        GenericCommands.LoadPatch();
    }
    private static void ClearYAML()
    {
        GenericCommands.ClearYAMLConfig();
    }

    private static void UseYAML()
    {
        GenericCommands.UseYAML();
    }

    private static void LoadYAML()
    {
        GenericCommands.LoadYAML();
    }

    private static void LoadSettings()
    {
        GenericCommands.LoadSettings();
    }

    private static void Options()
    {
        GenericCommands.Options();
    }

    private static void Logging()
    {
        GenericCommands.Logging();
    }

    private static void Randomize()
    {
        GenericCommands.Randomize();
    }

    private static void SaveRom()
    {
        GenericCommands.SaveRom();
    }

    private static void SaveSpoiler()
    {
        GenericCommands.SaveSpoiler();
    }

    private static void SavePatch()
    {
        GenericCommands.SavePatch();
    }

    private static void SaveHash()
    {
        GenericCommands.SaveSeedHash();
    }

    private static void GetSettingString()
    {
        GenericCommands.GetSelectedSettingString();
    }

    private static void GetFinalSettingString()
    {
        GenericCommands.GetFinalSettingString();
    }

    private static void PatchRom()
    {
        GenericCommands.PatchRom();
    }

    private static void CreatePatch()
    {
        GenericCommands.CreatePatch();
    }
    
    internal static void Exit()
    {
        _exiting = true;
    }
}
