$Title = 'add missing information'
$Message = 'Enter the field values'

$field1 = [Management.Automation.Host.fieldDescription] 'field1'
$field1.Label = 'Field &1'
$field1.HelpMessage = 'Help message'

$field2 = [Management.Automation.Host.fieldDescription] 'field2'
$field2.Label = 'Field &2'
$field2.DefaultValue = 'default value'

$Host.UI.Prompt($Title, $Message, @($field1, $field2))
