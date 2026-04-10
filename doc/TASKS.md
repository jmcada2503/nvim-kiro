## To Do

- Review bug with agent swap (context string still being added)
    > Context added when writing a prefix of the agent name
- Add possibility to add something from Kiro response to context
- Add a question to ask if the user wants to save the chat before closing Kiro with ctrl+c
- Research better ways to manage context in projects -> look for possible implementations to improve user experience on context management for a project

## Doing


## Done

- Review bug on reload module
    > Reload module is throwing an error sometimes when it needs to trigger the diff workflow
- Review possibility to make prompt editable
    * [x] Review possibility to make prompt modifiable in normal mode
    * [x] If there's no simple implementation, add a command to edit the last prompt, when the user saves the buffer the prompt would go back to kiro
