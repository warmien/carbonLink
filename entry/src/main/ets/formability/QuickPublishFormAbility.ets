import { FormExtensionAbility } from '@kit.FormKit';
import { formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { WidgetDataProvider } from '../widget/WidgetDataProvider';

export default class QuickPublishFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = WidgetDataProvider.getQuickPublishData();
    return formBindingData.createFormBindingData(data);
  }

  onUpdateForm(formId: string): formBindingData.FormBindingData {
    const data = WidgetDataProvider.getQuickPublishData();
    return formBindingData.createFormBindingData(data);
  }

  onRemoveForm(formId: string): void {
  }

  onCastToNormalForm(formId: string): void {
  }
}