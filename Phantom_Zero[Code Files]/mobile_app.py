from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.scrollview import ScrollView
from kivy.core.window import Window
import sys
sys.path.append('Purple-Phantom.AI')
from Purple_Phantom import predict_category

class ChatBubble(BoxLayout):
    def __init__(self, text, is_user=False, **kwargs):
        super().__init__(**kwargs)
        self.orientation = 'vertical'
        self.size_hint_y = None
        self.height = 50
        self.padding = 10
        self.spacing = 5
        if is_user:
            self.canvas.before.add(Color(0.6, 0.2, 0.8, 1))  # Purple for user
        else:
            self.canvas.before.add(Color(0.1, 0.1, 0.1, 0.8))  # Dark for AI
        with self.canvas.before:
            RoundedRectangle(pos=self.pos, size=self.size, radius=[15])
        label = Label(text=text, color=(1,1,1,1), size_hint_y=None, height=40)
        self.add_widget(label)

class ChatApp(App):
    def build(self):
        Window.clearcolor = (0, 0, 0.2, 1)  # Dark blue background
        layout = BoxLayout(orientation='vertical')
        
        self.chat_history = ScrollView(size_hint=(1, 0.8))
        self.chat_layout = BoxLayout(orientation='vertical', size_hint_y=None)
        self.chat_layout.bind(minimum_height=self.chat_layout.setter('height'))
        self.chat_history.add_widget(self.chat_layout)
        
        input_layout = BoxLayout(size_hint=(1, 0.2))
        self.text_input = TextInput(hint_text='Type your message...', multiline=False)
        send_button = Button(text='Send', on_press=self.send_message)
        
        input_layout.add_widget(self.text_input)
        input_layout.add_widget(send_button)
        
        layout.add_widget(self.chat_history)
        layout.add_widget(input_layout)
        
        return layout
    
    def send_message(self, instance):
        user_text = self.text_input.text
        if user_text:
            user_bubble = ChatBubble(user_text, is_user=True)
            self.chat_layout.add_widget(user_bubble)
            
            response = predict_category(user_text)
            ai_bubble = ChatBubble(response, is_user=False)
            self.chat_layout.add_widget(ai_bubble)
            
            self.text_input.text = ''
            self.chat_history.scroll_to(ai_bubble)

if __name__ == '__main__':
    ChatApp().run()