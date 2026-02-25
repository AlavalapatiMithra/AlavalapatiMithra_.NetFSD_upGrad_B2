let tasks = [];

export const addTaskCallback = (task, callback) => {
    setTimeout(() => {
        tasks.push(task);
        callback(`Task "${task}" added successfully.`);
    }, 500);
};


export const deleteTaskCallback = (task, callback) => {
    setTimeout(() => {
        tasks = tasks.filter(t => t !== task);
        callback(`Task "${task}" deleted successfully.`);
    }, 500);
};


export const listTasksCallback = (callback) => {
    setTimeout(() => {
        callback([...tasks]);
    }, 500);
};

export const addTaskPromise = (task) =>
    new Promise((resolve) => {
        setTimeout(() => {
            tasks.push(task);
            resolve(`Task "${task}" added successfully.`);
        }, 500);
    });

export const deleteTaskPromise = (task) =>
    new Promise((resolve) => {
        setTimeout(() => {
            tasks = tasks.filter(t => t !== task);
            resolve(`Task "${task}" deleted successfully.`);
        }, 500);
    });

export const listTasksPromise = () =>
    new Promise((resolve) => {
        setTimeout(() => {
            resolve([...tasks]);
        }, 500);
    });


export const addTaskAsync = async (task) => {
    const message = await addTaskPromise(task);
    return message;
};

export const deleteTaskAsync = async (task) => {
    const message = await deleteTaskPromise(task);
    return message;
};

export const listTasksAsync = async () => {
    const currentTasks = await listTasksPromise();
    return currentTasks;
};