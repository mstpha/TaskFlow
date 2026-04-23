# ✅ TaskFlow – Gestion intelligente de tâches

A modern mobile task management app built with Flutter and Supabase, allowing teams to organize work, track progress, and collaborate efficiently.

---

## 🚀 Technologies Used

**Frontend**
- Flutter – Cross-platform mobile framework
- Riverpod – State management (AsyncNotifier pattern)
- GoRouter – Navigation and auth redirects
- Google Fonts + Material 3 – UI styling

**Backend**
- Supabase – Authentication, PostgreSQL database, Row Level Security
- flutter_local_notifications – Scheduled local notifications

**Other**
- SharedPreferences – Dark mode persistence
- Flutter ARB + flutter_localizations – Internationalisation (EN / FR / AR)

---

## 📋 Prerequisites

- Flutter SDK >= 3.19
- Android Studio or VS Code with Flutter extension
- A Supabase account (free at supabase.com)
- Android device or emulator (minSdk 21+)

---

## 🔧 Installation and Setup

### 1. Create the Flutter project
```bash
flutter create taskflow
cd taskflow
```

### 2. Copy all source files into the project following the structure below

### 3. Set up Supabase
- Create a project at [supabase.com](https://supabase.com)
- Go to **SQL Editor** and run the schema (tables + RLS policies) from the section below
- Copy your **Project URL** and **anon key** into `lib/core/constants/app_constants.dart`

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Create the assets folder
```bash
mkdir assets/icons
```

### 6. Run the app
```bash
flutter run
```

---

## 🗄️ Supabase Schema

Run this in the Supabase SQL Editor:

```sql
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text not null,
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

create table public.projects (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  owner_id uuid references public.profiles(id) on delete cascade not null,
  color text default '#6366F1',
  member_ids uuid[] default '{}',
  created_at timestamptz default now()
);

create table public.tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  project_id uuid references public.projects(id) on delete cascade not null,
  created_by uuid references public.profiles(id) not null,
  assigned_to uuid references public.profiles(id),
  status text default 'Todo' check (status in ('Todo','In Progress','Review','Done')),
  priority text default 'Medium' check (priority in ('Low','Medium','High','Critical')),
  due_date timestamptz,
  created_at timestamptz default now()
);

-- Auto-create profile on sign-up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.tasks enable row level security;

create policy "profiles_select" on public.profiles for select using (true);
create policy "projects_select" on public.projects for select using (owner_id = auth.uid() or auth.uid() = any(member_ids));
create policy "projects_insert" on public.projects for insert with check (owner_id = auth.uid());
create policy "projects_update" on public.projects for update using (owner_id = auth.uid());
create policy "projects_delete" on public.projects for delete using (owner_id = auth.uid());
create policy "tasks_select" on public.tasks for select using (created_by = auth.uid() or assigned_to = auth.uid());
create policy "tasks_insert" on public.tasks for insert with check (created_by = auth.uid());
create policy "tasks_update" on public.tasks for update using (created_by = auth.uid() or assigned_to = auth.uid());
create policy "tasks_delete" on public.tasks for delete using (created_by = auth.uid());
```

---

## 📁 Project Structure

```
taskflow/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/        # Supabase keys, statuses, priorities
│   │   ├── theme/            # Light & dark Material 3 themes
│   │   └── router.dart       # GoRouter with auth redirect
│   ├── data/
│   │   ├── models/           # Task, Project, Profile data classes
│   │   └── services/         # Supabase calls, local notifications
│   ├── providers/
│   │   └── providers.dart    # All Riverpod providers
│   ├── presentation/
│   │   ├── auth/             # Login, Register screens
│   │   ├── tasks/            # Task list, Task form
│   │   ├── projects/         # Project list, Project detail
│   │   ├── profile/          # Profile & settings
│   │   └── widgets/          # TaskCard, MainShell (bottom nav)
│   └── l10n/                 # EN / FR / AR translation files
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

---

## ✨ Features

**🔐 Authentication**
- Register with name, email and password
- Login / Logout via Supabase Auth
- Auto-redirect based on session state

**📁 Projects**
- Create projects with name, description and color
- View all projects you own or are a member of
- Delete projects (cascades to tasks)

**✅ Tasks**
- Full CRUD — create, view, edit, delete tasks
- Set status: Todo / In Progress / Review / Done
- Set priority: Low / Medium / High / Critical
- Set due date with overdue detection
- Tasks grouped by status on the main screen
- Kanban-style tab view inside each project

**👥 Collaboration**
- Search users by name and assign tasks to them
- Assigned tasks appear in the assignee's task list

**🎨 UI / UX**
- Material 3 design with Inter font
- Color-coded priority and status chips
- Progress bar per project

**🌙 Dark Mode** — toggle from Tasks screen or Profile, persisted across restarts

**🔔 Notifications** — local notification scheduled 1 hour before task due date

**🌍 Internationalisation** — English, French, Arabic (ARB files)

**🧪 Tests** — unit tests in `test/widget_test.dart`

---

## 🎓 Context

Developed as a university mini-project (Flutter, L3/M1 level) demonstrating clean mobile architecture with a real cloud backend.

---

## 👨‍💻 Author

Adem ben Mustapha – [GitHub](https://github.com/mstpha)